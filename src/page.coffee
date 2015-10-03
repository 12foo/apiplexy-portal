# markdown page rendering

marked = require 'marked'

headingTracker = (headings) ->
    return (text, level) ->
        escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')
        id = 'md-' + escapedText
        if level < 4 then headings.push
            id: id
            level: level
            title: text
        return '<h' + level + ' id="' + id + '">' + text + '</h' + level + '>'

makeTOC = (headings) ->
    m '.toc', [
        m 'h4', 'Contents'
        m 'ul',
            style:
                paddingLeft: '0px'
                listStyleType: 'none'
        , headings.map (h) ->
            m 'li',
                style:
                    paddingLeft: '' + ((h.level - 1) * 1.5) + 'em'
                    marginTop: if h.level < 3 then '0.5em' else '0px'
                    fontWeight: if h.level < 3 then 'bold' else 'normal'
            , m 'a',
                style: cursor: 'pointer'
                onclick: ->
                    window.scroll 0, document.getElementById(h.id).offsetTop
            , h.title
    ]

module.exports =
    controller: (args) ->
        self = this

        self.content = m.prop null
        self.toc = m.prop null

        m.request
            method: 'GET'
            background: true
            url: "pages/#{args.page}"
            deserialize: (v) -> return v
        .then (md) ->
            m.startComputation()

            headings = []
            renderer = new marked.Renderer()
            renderer.heading = headingTracker headings
            self.content marked md, renderer: renderer

            if args.toc then self.toc makeTOC headings

            m.endComputation()

        return {
            hasTOC: args.toc || false
            loaded: -> return self.content() != null
            content: -> return m.trust self.content()
            toc: -> return self.toc()
        }


    view: (c) ->
        if !c.loaded()
            return m '.markdown.loading', 'Loading...'
        if c.hasTOC
            return m '.markdown.row', [
                m '.col-md-8.content', c.content()
                m '.col-md-4.toc', c.toc()
            ]
        else
            return m '.markdown.row', [
                m '.content', c.content()
            ]

