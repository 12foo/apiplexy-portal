# copy static files
require 'file?name=[name].[ext]!../index.html'
require 'file?name=[name].[ext]!../bootstrap.min.css'
require 'file?name=pages/[name].[ext]!../default-pages/index.md'
require 'file?name=pages/[name].[ext]!../default-pages/howto.md'

layout = require 'layout'
PageViewer = require 'page'

Page =
    controller: -> return page: m.route.param('page')
    view: (c) -> m.component PageViewer, page: c.page, toc: true

Portal =
    controller: ->
    view: (c) ->
        m '.row', [
            m '.col-md-8', m.component PageViewer, page: 'index.md', toc: false
            m '.col-md-4', [
                'login box'
            ]
        ]

m.route document.body, '/',
    '/': layout Portal
    '/pages/:page': layout Page

document.title = config.title
