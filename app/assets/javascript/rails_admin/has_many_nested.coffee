$(document).on 'rails_admin.dom_ready', ->
  $('[data-pjax-container] [data-pjax-container] .pjax').removeClass("pjax").addClass("pjax-nested")
  $('[data-pjax-container] [data-pjax-container] .pjax-form').removeClass("pjax").addClass("pjax-form-nested")
  $('[data-pjax-container-setup-action-container] [data-pjax-container-setup-action-link]').click()
  return

$(document).on 'click', '.pjax-nested', (event) ->
  if event.which > 1 || event.metaKey || event.ctrlKey
    return
  else if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container') || $(this).closest('[data-pjax-container]'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")
    url = $(this).data('href') || $(this).attr('href')
    url += (if (url.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'
    $.pjax
      container: "#" + id
      url: url
      timeout: 2000
      push: false
  else if $(this).data('href') # not a native #href, need some help
    window.location = $(this).data('href')

$(document).on 'submit', '.pjax-form-nested', (event) ->
  if $.support.pjax
    event.preventDefault()
    pjaxContainer = $($(this).data('pjax-container') || $(this).closest('[data-pjax-container]'))
    pjaxContainer = pjaxContainer[0]
    if !$(pjaxContainer).attr("id")
      $(pjaxContainer).attr('id', Math.random().toString().replace(".", ""))
    id = $(pjaxContainer).attr("id")
    url = this.action + (if (this.action.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'
    url += $(this).serialize()
    $.pjax
      container: "#" + id
      url: url
      timeout: 2000
      push: false
