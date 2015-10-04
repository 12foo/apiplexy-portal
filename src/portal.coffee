# copy static files
require 'file?name=[name].[ext]!../index.html'
require 'file?name=[name].[ext]!../bootstrap.min.css'
require 'file?name=pages/[name].[ext]!../default-pages/index.md'
require 'file?name=pages/[name].[ext]!../default-pages/howto.md'

state = require 'state'
layout = require 'layout'
requests = require 'requests'
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
        c =
            error: m.prop null
            success: m.prop null
            email: m.prop ''
            password: m.prop ''
            fullname: m.prop ''
            passwordVerify: m.prop ''
            needsActivation: m.prop false
            forgotPassword: m.prop false
            createAccount: m.prop false

        c.showMessages = -> [
            if c.error() then m '.alert.alert-danger', c.error() else null
            if c.success() then m '.alert.alert-success', c.success() else null
        ]

        c.doSignIn = (e) ->
            e.preventDefault()
            c.error null
            if c.email() == '' or c.password() == ''
                c.error "Please fill out all the fields."
                return
            requests.getToken c.email(), c.password()
            .then (token) ->
                console.log token
            , (err) ->
                c.error err.error

        c.doCreateAccount = (e) ->
            e.preventDefault()
            c.error null
            if c.email() == '' or c.fullname() == '' or c.password() == ''
                c.error "Please fill out all the fields."
                return
            if c.passwordVerify() != c.password()
                c.error "Your passwords don't match."
                return
            requests.createAccount c.email(), c.fullname(), c.password()
            .then (created) ->
                if created.active
                    c.success 'Account created. Please log in below.'
                    c.createAccount false
                else
                    c.needsActivation true

            , (err) ->
                c.error err.error

        c.doResetPassword = (e) ->

        return c

    view: (c) ->
        if state.token()
            m '.panel.panel-default', [
            ]
        else
            if c.createAccount()
                m '.panel.panel-default', [
                    m '.panel-heading', m 'h4', 'Create an account'
                    if c.needsActivation()
                        m '.panel-body', m 'p',
                        "We've sent you an activation email. Please check your inbox and follow the instructions."
                    else
                        m '.panel-body', [
                            m 'form',
                                onsubmit: c.doCreateAccount
                            , m 'fieldset', [
                                c.showMessages()
                                input 'text', 'Your email', 'you@example.com', c.email
                                input 'text', 'Your full name', 'Your Name', c.fullname
                                input 'password', 'Password', '', c.password
                                input 'password', 'Password (again)', '', c.passwordVerify
                                m 'button[type=submit].btn.btn-primary', 'Create Account'
                                m 'span',
                                    style: marginLeft: '1em'
                                , [
                                    'or  '
                                    m 'a',
                                        style: cursor: 'pointer'
                                        onclick: -> c.error null; c.createAccount false
                                    , 'go back'
                                ]
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
                            c.showMessages()
                            m 'p', 'We will send a reset link to your email.'
                            input 'text', 'Email', 'you@example.com', c.email
                            m 'button[type=submit].btn.btn-primary', 'Send link'
                            m 'span',
                                style: marginLeft: '1em'
                            , [
                                'or  '
                                m 'a',
                                    style: cursor: 'pointer'
                                    onclick: -> c.error null; c.forgotPassword false
                                , 'go back'
                            ]
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
                            c.showMessages()
                            m 'p', 'Sign in to manage your keys.'
                            input 'text', 'Email', 'you@example.com', c.email
                            input 'password', [
                                m 'span', 'Password ('
                                m 'a',
                                    style: cursor: 'pointer'
                                    onclick: -> c.error null; c.forgotPassword true
                                , "can't remember?"
                                m 'span', ')'
                            ], '', c.password
                            m 'button[type=submit].btn.btn-primary', 'Sign in'
                            m 'span',
                                style: marginLeft: '1em'
                            , [
                                'or  '
                                m 'a',
                                    style: cursor: 'pointer'
                                    onclick: -> c.error null; c.createAccount true
                                , 'create an account'
                            ]
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
