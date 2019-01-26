const convict = require('convict')

const config = convict({
    database_system_url: {
        format: String,
        default: '',
        env: "DATABASE_SYSTEM_URL"
    },
    database_url: {
        format: String,
        default: '',
        env: 'DATABASE_URL'
    },
    jwt_secret: {
        format: String,
        default: '',
        env: 'JWT_SECRET'
    },
    port: {
        format: 'port',
        default: 80,
        env: 'PORT'
    }
})

config.validate({ allowed: 'strict' })

module.exports = {
    databaseSystemUrl: config.get('database_system_url'),
    databaseUrl: config.get('database_url'),
    jwtSecret: config.get('jwt_secret'),
    port: config.get('port')
}