
api = window.config.portalAPIPath
redirect = (path) ->
    separator = if m.route.mode == 'search' then '?' else '#'
    return window.config.portalPath + '/' + separator + path

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
            after: redirect '/activated'
