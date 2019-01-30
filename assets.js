const express = require('express')
const passport = require('passport')
const fs = require('fs')
const path = require('path')
const multer = require('multer')
const uuidv4 = require('uuid/v4');
const repo = require('./repository')
const config = require('./config')

const router = express.Router();

router.get('/asset/:id', (req, res) => {
    const id = req.params.id;

    // get the asset
    repo.findAsset(id).then(asset => {
        if (!asset) {
            return res.status(404)
        }
        const assetData = asset.data

        // determine the filename
        const filename = assetData.key + assetData.extension;

        // get the size
        if (req.query.w) {
            const sizes = asset.data.sizes;
            filename = sizes[req.query.w]

            if (!filename) {
                return res.status(404)
            }
        }

        fs.createReadStream(path.join('./assets', filename)).pipe(res)
        return res.status(200);
    }).catch(error => {
        console.error(error);
        return res.status(500)
    })
})

router.post('/uploadAsset', 
    passport.authenticate('jwt', { session: false }),
    (req, res, next) => {
        // validate
        const siteId = req.query.siteId
        const userId = req.user.userId
        repo.validateZoneUser(siteId, userId).then(valid => {
            if (!valid) {
                return res.status(401)
            } else {
                next()
            }
        }).catch(err => {
            console.error(err);
            return res.status(500);
        })
    },
    multer({
        storage: multer.diskStorage({
            destination: path.join('./', config.assetsDirectory),
            filename: (req, file, cb) => {
                file.key = uuidv4();
                cb(null, `${file.key}${path.extname(file.originalname)}`);
            }
        })
    }).single('file'),
    (req, res) => {
        // file should be uploaded by now
        const siteId = req.query.siteId
        const userId = req.user.userId
        const file = req.file;
        const mimetype = file.mimetype;
        const originalFilename = file.originalname;
        const extension = path.extname(originalFilename);
        const key = file.key;
        const savedFilename = key + extension;

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
    }
)

module.exports = router