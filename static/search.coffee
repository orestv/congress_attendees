root = exports ? this

SEARCH_TIMEOUT = 250

class root.SearchBox

    constructor: (@input, @f_search, @f_select) ->
        @keyDownTimeout = null
        @input.onkeydown = @inputKeyPressed
        @input.onsearch = @scheduleSearch

    scheduleSearch: () =>
        if @keyDownTimeout?
            window.clearTimeout(@keyDownTimeout)
        @keyDownTimeout = window.setTimeout(@performSearch, SEARCH_TIMEOUT)

    inputKeyPressed: (event) =>
        if event.keyCode == 13
            @f_select()
        @scheduleSearch()

    performSearch: () =>
        text = @input.value
        @f_search(text)