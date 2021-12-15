const { environment } = require('@rails/webpacker')
const expose = require('./loaders/expose')

environment.loaders.prepend('expose', expose)

module.exports = environment
