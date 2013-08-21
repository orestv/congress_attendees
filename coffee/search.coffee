root = exports ? this

SEARCH_TIMEOUT = 250

class root.SearchBox

    constructor: (@input, @f_search, @f_select) ->
        @keyDownTimeout = null
        @input.onkeydown = @inputKeyPressed

    inputKeyPressed: (event) =>
        if event.keyCode == 13
            @f_select()
        if @keyDownTimeout?
            window.clearTimeout(@keyDownTimeout)
        @keyDownTimeout = window.setTimeout(@search, SEARCH_TIMEOUT)

    search: () =>
        text = @input.value
        @f_search(text)