var webpack = require('webpack');
var path = require('path');
module.exports = {
    entry: {
        prometheus: [
            'webpack/hot/dev-server',
            './src/javascript/main'
        ]
    },
    output: {
        path: "./dist",
        filename: '[name].js'
    },
    devServer: {
        contentBase: "./dist"
    },
    module: {
        loaders: [
            {
                test: /\.scss$/,
                loader:'style!css!sass?outputStyle=expanded&' +
                'includePaths[]=' +
                (path.resolve(__dirname, './src/stylesheets/main'))
            },
            {
                test: /\.css$/,
                loader: "style!css"
            }
        ]
    }
};
