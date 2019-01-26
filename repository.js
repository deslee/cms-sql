const { Pool } = require('pg')
const config = require('./config')

const pool = new Pool({
    connectionString: config.databaseSystemUrl
})

async function authenticate(email, password, data) {
    const res = await pool.query('SELECT * from app_private.authenticate($1, $2, $3)', [email, password, data ? JSON.stringify(data) : '{}'])
    if (res.rowCount !== 0) {
        // return the session
        return res.rows[0]
    } else {
        return null;
    }
}
module.exports.authenticate = authenticate

async function findSession(token) {
    const res = await pool.query('SELECT * FROM app_private.active_sessions WHERE token=$1', [token])
    if (res.rowCount !== 0) {
        return res.rows[0]
    } else {
        return null;
    }
}
module.exports.findSession = findSession