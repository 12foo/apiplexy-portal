# markdown page rendering

marked = require 'marked'

module.exports =
    controller: (args) ->
        self = this

        self.content = m.prop null
        m.request
            method: 'GET'
            background: true
            url: "pages/#{args.page}"
            deserialize: (v) -> return v
        .then (md) ->
            m.startComputation()
            self.content marked md
            m.endComputation()

        return {
            hasTOC: args.toc || false
            loaded: -> return self.content() != null
            content: -> return self.content()
            toc: -> return makeTOC self.content()
        }


    view: (c) ->
        if !c.loaded()
            return m '.markdown.loading', 'Loading...'
        if c.hasTOC
            return m '.markdown.row', [
                m '.col-md-4.toc', 'blort'
                m '.col-md-8.content', m.trust c.content()
            ]
        else
            return m '.markdown.row', [
                m '.content', m.trust c.content()
            ]

