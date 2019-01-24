// IMPORTS


const path                 = require('path');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");


// 




module.exports = {
  entry: path.resolve(__dirname, 'index.js'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/dist/',
    filename: 'redmine.js'
  },

  devServer: {
    port: 8000,
    historyApiFallback: {
      index: 'index.html'
    }
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: "redmine.css"
    })
  ],

  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack-loader',
      options: {
        debug: true
      }
    }, {
      test: /\.(s)css$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: [
        MiniCssExtractPlugin.loader,
        'css-loader',
        'sass-loader'
      ]
    }, {
      test: /\.(woff|ttf|eot|svg)(\?[a-z0-9]+)?$/,
      use: 'file-loader'
    }]
  }
  
};
