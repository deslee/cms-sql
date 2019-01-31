const app = require('./app')
const config = require('./config')

app.listen(config.port, (err) => {
    if (err) {
        console.log(err);
        return;
    }
    console.log('listening to ' + config.port);
})