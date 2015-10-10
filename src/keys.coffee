state = require 'state'
requests = require 'requests'

# horrible! but there's no other way
typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

module.exports =
    controller: ->
        c = {}

        c.keys = m.prop null
        c.types = m.prop null
        c.prepDelete = m.prop []
        c.error = m.prop null
        c.loading = m.prop true
        c.creating = m.prop false
        c.newKey = m.prop null

        c.clear = ->
            c.newKey type: '', realm: ''

        c.clear()

        c.renderKey = (key) -> m 'tr', [
            m 'td', [
                m 'code', key.id
                m 'br'
                m 'b', key.realm
                m 'br'
                m 'span.small', 'Type: ' + key.type
            ]
            m 'td', m 'table', m 'tbody', _.pairs(key.data).map (d) ->
                m 'tr', [
                    m 'th', d[0]
                    m 'td', if typeIsArray(d[1])
                        m 'ul', d[1].map (i) ->
                            m 'li', m 'code', i
                    else
                        m 'code', d[1]
                ]
            m 'td', 'status'
            m 'td', if _.includes c.prepDelete(), key.id
                [
                    m 'button.btn.btn-xs.btn-default',
                        onclick: -> c.prepDelete _.without(c.prepDelete(), key.id)
                    , 'Cancel'
                    m 'br'
                    m 'button.btn.btn-xs.btn-danger',
                        onclick: -> c.deleteKey key.id
                    , 'I\'m sure'
                ]
            else
                m 'button.btn.btn-xs.btn-danger',
                    onclick: -> c.prepDelete _.xor c.prepDelete(), [key.id]
                , 'Delete'
        ]

        c.createKey = (e) ->
            e.preventDefault()
            c.error null
            if c.newKey().type == '' or c.newKey().realm == ''
                c.error 'Please give both a key type and a realm to create your key.'
                return
            requests.createKey c.newKey().type, c.newKey().realm
            .then (key) ->
                m.startComputation()
                c.keys _.xor c.keys(), [key]
                c.clear()
                c.creating false
                m.endComputation()
            , (err) -> c.error err.error

        c.deleteKey = (id) ->
            requests.deleteKey id
            .then (ok) ->
                m.startComputation()
                c.prepDelete _.without c.prepDelete(), ok.deleted
                c.keys _.reject(c.keys(), (k) -> k.id == ok.deleted)
                m.endComputation()
            , (err) ->
                window.alert(err.error)

        # load keys and key types
        m.sync([requests.getKeyTypes(), requests.getKeys()])
        .then (results) ->
            m.startComputation()
            c.types results[0]
            c.keys results[1]
            c.loading false
            m.endComputation()

        return c
    view: (c) -> if c.loading()
        m 'p', 'Loading... please wait.'
    else
        m '', [
            m '.row', [
                m '.col-md-12', [
                    m 'h1', 'Your API keys'
                    if c.keys().length == 0
                        m 'p', "You don't have any keys at the moment."
                    else
                        m 'table.table.table-striped.table-condensed', [
                            m 'thead', m 'tr', [
                                m 'th', 'Key ID / Realm'
                                m 'th', 'Key Profile'
                                m 'th', 'Quota'
                                m 'th', 'Delete'
                            ]
                            m 'tbody', c.keys().map c.renderKey
                        ]
                ]
            ]

            m 'hr'

            if c.creating()
                m '.create-key.well', [
                    m 'form',
                        onsubmit: c.createKey
                    , m 'fieldset', [
                        m 'legend', 'Create a new key'
                        if c.error()
                            m '.row', m '.col-md-12', m '.alert.alert-warning', c.error()
                        m 'row', [
                            m '.col-md-6', [
                                m 'label', 'Key Type'
                                m 'table', m 'tbody', _.values(c.types()).map (t) ->
                                    m 'tr',
                                        onclick: -> c.newKey().type = t.name
                                    , [
                                        m 'td',
                                            style:
                                                verticalAlign: 'top'
                                                paddingRight: '3px'
                                        , m 'input[type=radio]',
                                            checked: c.newKey().type == t.name
                                        m 'td', [
                                            m 'b', t.name
                                            m 'br'
                                            m 'span.small', t.description
                                        ]
                                    ]
                            ]
                            m '.col-md-6', [
                                m '.form-group', [
                                    m 'label', 'Key Realm (usually your site or app)'
                                    m 'p.small.text-muted', '''
                                    If you intend to use this key from a website or browser app, enter
                                    your site or app's domain here (without the http[s]). If your app
                                    lives at https://coolapp.mydomain.com/app/, put coolapp.mydomain.com.
                                    The key will not work if the realm and your domain don't match!
                                    For native apps, just put a name that makes sense to you. Native
                                    apps are not domain-checked.
                                    '''
                                    m 'input[type=text].form-control',
                                        value: c.newKey().realm
                                        onchange: m.withAttr 'value', (v) -> c.newKey().realm = v
                                ]
                            ]
                        ]
                        m '.row', m '.col-md-12', m '.pull-right',
                            m 'button[type=submit].btn.btn-primary', 'Create Key'
                    ]
                ]
            else
                m 'button.btn.btn-primary',
                    onclick: -> c.creating true
                , 'Create a new key'
        ]
