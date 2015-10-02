# page layout

config = window.config

module.exports = (content) ->
    return {
        view: -> return [
            m '.navbar.navbar-default', m '.container', [
                m '.navbar-header', [
                    m 'a.navbar-brand',
                        href: '/'
                        config: m.route
                    , config.title
                    m 'ul.nav.navbar-nav', config.pages.map (page) ->
                        m 'li', m 'a',
                            href: '/pages/' + page.page
                            config: m.route
                        , page.title
                ]
            ]
            m '.container', content
        ]
    }
