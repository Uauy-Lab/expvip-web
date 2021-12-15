module.exports = {
  rules: [{
    test: /expression_bar/,
    use: [{
      loader: 'expose-loader',
      options: 'ExpressionBar'
    }]
  }]
}