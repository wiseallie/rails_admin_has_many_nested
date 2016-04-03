$(document).on 'rails_admin.dom_ready', ->
  $('[data-pjax-container] [data-pjax-container] [data-pjax-container] .pjax').not("[data-pjax-enabled]").removeClass("pjax").attr('data-pjax-nested', true)
  $('[data-pjax-container] [data-pjax-container] [data-pjax-container] .pjax-form').removeClass("pjax-form").attr('data-pjax-form-nested', true)

  $('[data-pjax-container]').find("[data-pjax-enabled], [data-pjax-nested]").removeClass("pjax")
  $('[data-pjax-container]').find("[data-pjax-form-nested]").removeClass("pjax-form")

  $('[data-nested-pjax-container] [data-pjax-nested]').attr('data-pjax-nested-list-link', true)
  $('[data-nested-pjax-container] [data-pjax-form-nested]').attr('data-pjax-nested-list-form', true)

  $('[data-pjax-container] .pjax').not("[data-pjax-enabled]").not("[data-pjax-nested]").removeClass("pjax").attr('data-pjax-unnested', true)
  $('[data-pjax-container] .pjax-form').not("[data-pjax-form-nested]").removeClass("pjax-form").attr('data-pjax-form-unnested', true)

  return

$(document).on 'click', '[data-pjax-nested-list-link]', (event) ->
  event.preventDefault()
  $(this).parents("ul:first").find("li").removeClass("active")
  $(this).parents("li:first").addClass("active")
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
    if($(pjaxContainer).data('nested-pjax-container') || $(this).data('pjax-nested-list-link'))
      url += "&pjax_nested_list=true"
      $(pjaxContainer).attr('data-nested-pjax-container', true)
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
    if($(pjaxContainer).data('nested-pjax-container') || $(this).data('pjax-nested-list-form'))
      url += "&pjax_nested_list=true"
      $(pjaxContainer).attr('data-nested-pjax-container', true)

    url += $(this).serialize()

    $.pjax
      container: "#" + id
      url: url
      timeout: 60000
      push: false
    return
