# page layout

config = window.config
state = require 'state'

module.exports = (content) ->
    return {
        view: -> return [
            m '.navbar.navbar-default', m '.container', [
                m '.navbar-header', [
                    m 'a.navbar-brand',
                        href: '/'
                        config: m.route
                    , config.title
                ]
                m 'ul.nav.navbar-nav', config.pages.map (page) ->
                    m 'li', m 'a',
                        href: '/pages/' + page.page
                        config: m.route
                    , page.title
                if state.token()
                    m 'ul.nav.navbar-nav.navbar-right', [
                        m 'li', m 'a',
                            href: '/keys'
                            config: m.route
                        , 'Keys'
                        m 'li', m 'a',
                            href: '/account'
                            config: m.route
                        , 'Account'
                        m 'li', m 'a',
                            style: cursor: 'pointer'
                            onclick: ->
                                state.logout()
                                m.route '/'
                        , 'Sign out'
                    ]
            ]
            m '.container', content
        ]
    }
