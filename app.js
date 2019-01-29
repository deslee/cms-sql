const express = require('express')
const bodyParser = require('body-parser')
const { postgraphile } = require('postgraphile')
const passport = require('passport')
const LocalStrategy = require('passport-local').Strategy
const passportJWT = require('passport-jwt')
const cors = require('cors')
const expressPlayground = require('graphql-playground-middleware-express').default
const jsonwebtoken = require('jsonwebtoken')
const fs = require('fs')
const path = require('path')
const os = require('os')
const multer = require('multer')
const uuidv4 = require('uuid/v4');

const config = require('./config')
const repo = require('./repository')

const app = express();

app.use(cors())

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
                    userId: session.user_id,
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
app.use(bodyParser.urlencoded())
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
                    userId: user.userId
                },
                config.jwtSecret
            )
            return res.status(200).json({ token: token })
        }
    })(req, res)
})

app.get('/asset/:id', (req, res) => {
    const id = req.params.id;

    // get the asset
    const asset = null;

    // determine the filename
    const filename = null;

    // get the size
    if(req.query.w) {
        const sizes = asset.data.sizes;
        filename = sizes[req.query.w]

        if (!filename) {
            return res.status(404)
        }
    }

    fs.createReadStream(path.join('./assets', filename)).pipe(res)
    return res.status(200);
})

app.post('/uploadAsset', passport.authenticate('jwt', { session: false }), multer().single('file'), (req, res) => {
    const key = uuidv4()
    const siteId = req.body.siteId;
    const userId = req.user.userId;
    const file = req.file;
    const mimetype = file.mimetype;
    const originalFilename = file.originalname;
    const extension = path.extname(originalFilename);
    const savedFilename = key + extension;

    // validate userId can access siteId
    repo.validateZoneUser(siteId, userId).then(valid => {
        if (!valid) {
            return res.status(401)
        }

        // write the file to directory
        var saveTo = path.join('./assets', savedFilename);
        file.buffer.pipe(fs.createWriteStream(saveTo))

        // save asset to database
        var asset = {
            id: key,
            state: 'NONE',
            siteId: siteId,
            type: mimetype,
            data: JSON.stringify({
                extension: extension,
                originalFilename: originalFilename,
                key: key
            })
        }

        repo.insertAsset(asset).then(() => {
            res.writeHead(200, { 'Connection': 'close' });
            res.end("That's all folks!");
        })
    })
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
            if (err) {
                req.status(500).json({ err })
            } else {
                gqlHandler(req, res, next)
            }
        })
    })(req, res)
})

module.exports = app;