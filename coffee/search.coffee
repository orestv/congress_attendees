root = exports ? this

SEARCH_TIMEOUT = 1

class root.SearchBox

    constructor: (@input, @f_search) ->
        @keyDownTimeout = null
        @input.onkeydown = @inputKeyPressed

    inputKeyPressed: (event) =>
        if @keyDownTimeout?
            window.clearTimeout(@keyDownTimeout)
        @keyDownTimeout = window.setTimeout(@search, SEARCH_TIMEOUT)

    search: () =>
        text = @input.value
        @f_search(text)