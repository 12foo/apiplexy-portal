# copy static files
require 'file?name=[name].[ext]!../index.html'
require 'file?name=[name].[ext]!../bootstrap.min.css'
require 'file?name=pages/[name].[ext]!../default-pages/index.md'
require 'file?name=pages/[name].[ext]!../default-pages/howto.md'

state = require 'state'
layout = require 'layout'
PageViewer = require 'page'

Page =
    controller: -> return page: m.route.param('page')
    view: (c) -> m.component PageViewer, page: c.page, toc: true

input = (type, label, placeholder, target) ->
    m '.form-group', [
        m 'label', label
        m 'input.form-control',
            value: target()
            type: type
            placeholder: placeholder
            onchange: m.withAttr 'value', target
    ]

LoginBox =
    controller: ->
        return {
            email: m.prop null
            password: m.prop null
            fullname: m.prop null
            passwordVerify: m.prop null
            forgotPassword: m.prop false
            createAccount: m.prop false
            doSignIn: ->
            doCreateAccount: ->
            doResetPassword: ->
        }
    view: (c) ->
        if state.token()
            m '.panel.panel-default', [
            ]
        else
            if c.createAccount()
                m '.panel.panel-default', [
                    m '.panel-heading', m 'h4', 'Create an account'
                    m '.panel-body', [
                        m 'form',
                            onsubmit: c.doCreateAccount
                        , m 'fieldset', [
                            input 'text', 'Your email', 'you@example.com', c.email
                            input 'text', 'Your full name', 'Your Name', c.fullname
                            input 'password', 'Password', '', c.password
                            input 'password', 'Password (again)', '', c.passwordVerify
                        ]
                        m 'button[type=submit].btn.btn-primary]', 'Create Account'
                        m 'span',
                            style: marginLeft: '1em'
                        , [
                            'or  '
                            m 'a',
                                style: cursor: 'pointer'
                                onclick: -> c.createAccount !c.createAccount()
                            , 'go back'
                        ]
                    ]
                ]
            else if c.forgotPassword()
                m '.panel.panel-default', [
                    m '.panel-heading', m 'h4', 'Reset your password'
                    m '.panel-body', [
                        m 'form',
                            onsubmit: c.doResetPassword
                        , m 'fieldset', [
                            m 'p', 'We will send a reset link to your email.'
                            input 'text', 'Email', 'you@example.com', c.email
                        ]
                        m 'button[type=submit].btn.btn-primary]', 'Send link'
                        m 'span',
                            style: marginLeft: '1em'
                        , [
                            'or  '
                            m 'a',
                                style: cursor: 'pointer'
                                onclick: -> c.forgotPassword !c.forgotPassword()
                            , 'go back'
                        ]
                    ]
                ]
            else
                m '.panel.panel-default', [
                    m '.panel-heading', m 'h4', 'Manage your keys'
                    m '.panel-body', [
                        m 'form',
                            onsubmit: c.doSignIn
                        , m 'fieldset', [
                            m 'p', 'Sign in to manage your keys.'
                            input 'text', 'Email', 'you@example.com', c.email
                            input 'password', [
                                m 'span', 'Password ('
                                m 'a',
                                    style: cursor: 'pointer'
                                    onclick: -> c.forgotPassword !c.forgotPassword()
                                , "can't remember?"
                                m 'span', ')'
                            ], '', c.password
                        ]
                        m 'button[type=submit].btn.btn-primary]', 'Sign in'
                        m 'span',
                            style: marginLeft: '1em'
                        , [
                            'or  '
                            m 'a',
                                style: cursor: 'pointer'
                                onclick: -> c.createAccount !c.createAccount()
                            , 'create an account'
                        ]
                    ]
                ]

Portal =
    controller: ->
    view: (c) ->
        m '.row', [
            m '.col-md-8', m.component PageViewer, page: 'index.md', toc: false
            m '.col-md-4', m.component LoginBox
        ]

m.route document.body, '/',
    '/': layout Portal
    '/pages/:page': layout Page

document.title = config.title
