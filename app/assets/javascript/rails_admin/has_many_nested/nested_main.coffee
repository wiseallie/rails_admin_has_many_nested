$(document).on 'rails_admin.dom_ready', ->
  $('[data-pjax-container-nested] .pjax').attr({'data-pjax-nested': true}).removeClass(".pjax")
  $('[data-pjax-container-nested] .pjax-form, [data-pjax-container-nested] form').attr({'data-pjax-form-nested': true}).removeClass(".pjax-form")

  $("[data-pjax-nested]").removeClass("pjax").attr({'data-remote': true, 'data-type': 'html'})
  $("[data-pjax-form-nested]").removeClass("pjax-form").attr({'data-remote': true, 'data-type': 'html'})

  return

$(document).on 'click', '.item-menu-tabs li a', (event) ->
  target = $(event.target)
  $(target).parents(".item-menu-tabs:first").find('li').removeClass("active")
  $(target).parents("li:first").addClass("active")

$(document).on 'ajax:before', (event, xhr, settings)  ->
  $('.alert-dismissible').remove();
  return

$(document).on 'ajax:remotipartSubmit', (event, xhr, settings)  ->
  $(document).trigger('pjax:start')
  target = $(event.target)
  if $(target).is("[data-pjax-nested]") || $(target).is("[data-pjax-form-nested]")
    xhr.setRequestHeader('X-PJAX', 'true')
    xhr.setRequestHeader('X-PJAX-NESTED', 'true')
    dataType = $(target).attr('data-type') || ($.ajaxSettings && $.ajaxSettings.dataType)
    xhr.setRequestHeader('accept', 'text/html')
    settings.url = settings.url + (if (settings.url.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'

  return


$(document).on 'ajax:beforeSend', (event, xhr, settings)  ->
  $(document).trigger('pjax:start')
  target = $(event.target)
  if $(target).is("[data-pjax-nested]") || $(target).is("[data-pjax-form-nested]")
    xhr.setRequestHeader('X-PJAX', 'true')
    xhr.setRequestHeader('X-PJAX-NESTED', 'true')
    dataType = $(target).attr('data-type') || ($.ajaxSettings && $.ajaxSettings.dataType)
    if (dataType == undefined)
      xhr.setRequestHeader('accept', 'text/html')
    settings.url = settings.url + (if (settings.url.indexOf('?') != -1) then '&' else '?') + 'pjax_nested=true'
  return


$(document).on 'ajax:success', (event, data, status, xhr) ->
  target = $(event.target)
  if $(target).is("[data-pjax-nested]") || $(target).is("[data-pjax-form-nested]")
    pjaxContainer = $($(target).attr('data-pjax-container') || $(target).parents('[data-pjax-container-nested]:first')|| $(target).parents('[data-pjax-container]:first'))
    $(pjaxContainer).attr('data-pjax-container-nested', true)
    $(pjaxContainer).html(data)
    $(document).trigger('pjax:stop')
    $(document).trigger('rails_admin.dom_ready')
  return


$(document).on 'ajax:error', (event, xhr, status, error) ->
  target = $(event.target)
  if $(target).is("[data-pjax-nested]") || $(target).is("[data-pjax-form-nested]")
    pjaxContainer = $($(target).attr('data-pjax-container') || $(target).parents('[data-pjax-container-nested]:first')|| $(target).parents('[data-pjax-container]:first'))
    $(pjaxContainer).attr('data-pjax-container-nested', true)
    $(pjaxContainer).html(xhr.responseText)
    $(document).trigger('pjax:stop')
    $(document).trigger('rails_admin.dom_ready')
  return
