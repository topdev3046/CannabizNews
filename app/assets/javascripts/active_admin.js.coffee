#= require active_admin/base
//= require activeadmin/froala_editor/froala_editor.pkgd.min
//= require activeadmin/froala_editor_input

$ ->
  $('.froala_editor').froalaEditor
    imageUploadURL: '/admin/blogs/upload_froala_image'
    imageUploadParams: authenticity_token: $('meta[name="csrf-token"]').attr 'content'