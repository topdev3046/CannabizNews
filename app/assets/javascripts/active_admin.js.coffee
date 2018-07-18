#= require active_admin/base
//= require activeadmin/froala_editor/froala_editor.pkgd.min
//= require activeadmin/froala_editor_input

$(function() {
  $('#edit').froalaEditor({
    // Set the image upload URL.
    imageUploadURL: '/upload_image',

    imageUploadParams: {
      id: 'my_editor'
    }
  })
});