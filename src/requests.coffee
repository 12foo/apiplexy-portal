
api = window.config.connect
portalLink = (path) ->
    separator = if m.route.mode == 'search' then '?' else '#'
    return window.location.protocol + '//' + window.location.host + window.location.pathname + separator + path

exports.getToken = (email, password) ->
    return m.request
        method: 'POST'
        url: api + '/account/token'
        data:
            email: email
            password: password

exports.createAccount = (email, name, password) ->
    return m.request
        method: 'POST'
        url: api + '/account'
        data:
            email: email
            name: name
            password: password
            # the portal will replace 'CODE' with the actual activation code
            # in the email
            link: portalLink '/activate/CODE'

exports.activateAccount = (code) ->
    return m.request
        method: 'GET'
        url: api + '/account/activate/' + code
        background: true
