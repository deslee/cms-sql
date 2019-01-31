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

async function validateZoneUser(zoneId, userId) {
    const res = await pool.query('SELECT count(*) from app_public.zone_user zu where zu.zone_id=$1 and zu.user_id = $2', [zoneId, userId])
    if (res.rowCount > 0) {
        return Number(res.rows[0].count) > 0
    } else {
        return null
    }
}
module.exports.validateZoneUser = validateZoneUser

async function insertAsset({ id, state, siteId, type, data }) {
    const values = [
        id, siteId, state, type, data
    ]
    const res = await pool.query('INSERT INTO app_public.asset (id, zone_id, state, type, data) values ($1, $2, $3, $4, $5)', values)
    console.log(res);
}
module.exports.insertAsset = insertAsset

async function findAsset(id) {
    const res = await pool.query('SELECT * FROM app_public.asset a WHERE a.id=$1', [id])
    if (res.rowCount > 0) {
        return res.rows[0]
    } else {
        return null
    }
}
module.exports.findAsset = findAsset