# global application state
lscache = require 'lscache'

token = m.prop null

do ->
    t = lscache.get 'token'
    if t then token t

module.exports =
    token: token
    logout: ->
        token null
        lscache.remove 'token'
    login: (t) ->
        token t
        lscache.set 'token', t, 120

