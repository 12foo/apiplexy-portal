var webpack = require("webpack");

module.exports = {
    entry: ["./src/portal"],
    output: {
        path: __dirname + "/dist",
        filename: "apiplexy-portal.js",
        publicPath: "/"
    },
    module: {
        loaders: [
            { test: /\.coffee$/, loader: "coffee-loader" }
        ]
    },
    plugins: [
        new webpack.ProvidePlugin({
            "m": "mithril",
            "_": "lodash"
        }),
    ],
    resolve: {
        modulesDirectories: ["./src", "./node_modules"],
        extensions: ["", ".coffee", ".webpack.js", ".web.js", ".js"]
    }
}
