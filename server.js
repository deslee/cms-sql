const app = require('./server/app')
const config = require('./server/config')

app.listen(config.port, (err) => {
    if (err) {
        console.log(err);
        return;
    }
    console.log('listening to ' + config.port);
})