$(document).on 'rails_admin.dom_ready', ->
  $('[data-pjax-iframe-container] .pjax').not('[data-pjax-nested-list-link]').attr('data-pjax-nested', true)
  $('[data-pjax-iframe-container] .pjax-form').removeClass("pjax-form").attr('data-pjax-form-nested', true)

  $("[data-pjax-nested], [data-pjax-nested-list-link]").removeClass("pjax")
  $("[data-pjax-form-nested]").removeClass("pjax-form")

  return

$(document).on 'click', '[data-pjax-nested-list-link]', (event) ->
  event.preventDefault()
  $(this).parents("ul:first").find("li").removeClass("active")
  $(this).parents("li:first").addClass("active")
  pjaxContainer = $($(this).data('pjax-container') || $(this).parents('[data-pjax-container]:last'))
  url = $(this).attr('href');
  iframeId = Math.random().toString().replace(".", "")
  $(this).attr('i-frame-id', iframeId)
  $(pjaxContainer).html("<iframe id='#{iframeId}' seamless='1' class='auto-resize-iframe' width='100%' scrolling='no'></iframe>")
  $(document).trigger("pjax:start")
  $("iframe##{iframeId}").attr('src', url)
  $("iframe##{iframeId}").iframeAutoHeight({debug: true})
  return

$(document).on 'click', '[data-pjax-unnested]', (event) ->
  if event.which > 1 || event.metaKey || event.ctrlKey
    return
  else if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container') || $(this).parents('[data-pjax-container]:last'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")
    url = $(this).data('href') || $(this).attr('href')
    $.pjax
      container: "#" + id
      url: url
      timeout: 60000
    return



$(document).on 'click', '[data-pjax-nested]', (event) ->
  if event.which > 1 || event.metaKey || event.ctrlKey
    return
  else if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container')|| $(this).closest('[data-nested-pjax-container]').length && $(this).closest('[data-nested-pjax-container]') || $(this).closest('[data-pjax-container]'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")

    url = $(this).data('href') || $(this).attr('href')
    url += (if (url.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'
    # if($(pjaxContainer).data('nested-pjax-container') || $(this).data('pjax-nested-list-link'))
    #   url += "&pjax_nested_list=true"
    #   $(pjaxContainer).attr('data-nested-pjax-container', true)
    $.pjax
      container: "#" + id
      url: url
      timeout: 60000
      push: false
    return

$(document).on 'submit', '[data-pjax-form-unnested]', (event) ->
  if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container')|| $(this).parents('[data-pjax-container]:last'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")

    url = this.action + (if (this.action.indexOf('?') != -1) then '&' else '?')
    url += $(this).serialize()

    $.pjax
      container: "#" + id
      url: url
      timeout: 60000
    return

$(document).on 'submit', '[data-pjax-form-nested]', (event) ->
  if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container')|| $(this).closest('[data-nested-pjax-container]').length && $(this).closest('[data-nested-pjax-container]') || $(this).closest('[data-pjax-container]'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")

    url = this.action + (if (this.action.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'
    # if($(pjaxContainer).data('nested-pjax-container') || $(this).data('pjax-nested-list-form'))
    #   url += "&pjax_nested_list=true"
      # $(pjaxContainer).attr('data-nested-pjax-container', true)

    url += $(this).serialize()

    $.pjax
      container: "#" + id
      url: url
      timeout: 60000
      push: false
    return
