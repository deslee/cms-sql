const express = require('express')
const bodyParser = require('body-parser')
const { postgraphile } = require('postgraphile')
const passport = require('passport')
const LocalStrategy = require('passport-local').Strategy
const passportJWT = require('passport-jwt')
const expressPlayground = require('graphql-playground-middleware-express').default
const jsonwebtoken = require('jsonwebtoken')

const config = require('./config')
const repo = require('./repository')

const app = express();

// graphql middleware
// configure local strategy (for token endpoint)
passport.use(new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    session: false
}, (email, password, done) => {
    repo.authenticate(email, password, {})
        .then(session => {
            if (session && session.user_id && session.token) {
                done(null, {
                    id: session.user_id,
                    sessionId: session.token
                })
                return
            } else {
                done(null, null)
                return
            }
        })
        .catch(err => done(err, null, null))
}));

// configure jwt strategy
passport.use(new passportJWT.Strategy({
    jwtFromRequest: passportJWT.ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: config.jwtSecret
}, (jwtPayload, cb) => {
    if (jwtPayload.userId && jwtPayload.sessionId) {
        repo.findSession(jwtPayload.sessionId).then(session => {
            if (session && session.user_id && session.token) {
                cb(null, {
                    userId: session.user_id,
                    sessionId: session.token
                });
                return
            } else {
                cb(null, null);
            }
        }).catch(err => {
            cb(err);
        })
    } else {
        cb(null, null);
    }
}))

// express middleware
app.use(bodyParser.json())
app.use(passport.initialize())

// configure token endpoint
app.post('/token', (req, res) => {
    passport.authenticate('local', { session: false }, (err, user, info) => {
        if (err) {
            console.log(err)
        }

        if (err || !user) {
            return res.status(400).json({
                message: info ? info.message : 'Login failed'
            })
        } else {
            const token = jsonwebtoken.sign(
                {
                    sessionId: user.sessionId,
                    userId: user.id
                },
                config.jwtSecret
            )
            return res.status(200).json({ token: token })
        }
    })(req, res)
})

// configure postgraphile
const gqlHandler = postgraphile(
    config.databaseUrl,
    'app_public',
    {
        appendPlugins: [],
        watchPg: true,
        graphiql: false,
        dynamicJson: true,
        ignoreRBAC: true,
        ignoreIndexes: true,
        showErrorStack: true,
        legacyRelations: 'omit',
        simpleCollections: 'both',
        pgSettings: async req => {
            return {
                'claims.userId': req.user && req.user.userId,
                'claims.role': req.user && 'cms_app_user'
            }
        }
    }
)

// playground
app.use('/playground', expressPlayground({
    endpoint: '/graphql'
}))

// graphql endpoint
app.use((req, res, next) => {
    passport.authenticate('jwt', { session: false }, (err, user, info) => {
        req.login(user, { session: false }, err => {
            gqlHandler(req, res, next)
        })
    })(req, res)
})

module.exports = app;