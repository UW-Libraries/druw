// This adds new agent fields to the edit form.
//
// Duplicated from https://github.com/aic-collections/aicdams-lakeshore/blob/0eda8f1407d89cb86fc7284ed6c235114407e020/app/assets/javascripts/add_annotation.js
//
// It uses handelbars.js to create a template into which is passed a field name (complex_creator), index value
// and class. This returns a new html string with the fields for the agent.
// The hydra-editor gem takes care of the bulk of the actions such attaching the listeners to the "Add" button
// and inserting the new field into the html form.
//
// Once inserted, the resulting html form should produce a parameters hash that looks like:
//
// {
//   "complex_creators_attributes" => {
//     "0" => {"agent_name"=>"Jane Doe", "_destroy"=>"0", "id"=>"37f13bdf-a664-4015-b590-4a66850a9ab6"},
//     "1" => {"agent_name"=>"John Doe", "_destroy"=>"0", "id"=>""}
//   }
// }
//
// TODOs:
//   - select needs to pull values from the Agent class
//   - QA needs to be involved to query existing agents
//
//= require hydra-editor/hydra-editor
//= require handlebars-v3.0.3

var source = "<li class=\"field-wrapper input-group input-append\">" +
  "<input class=\"string {{class}} optional form-control generic_file_{{name}} form-control multi-text-field\" name=\"generic_file[{{name}}_attributes][{{index}}][content]\" aria-labelledby=\"generic_file_{{name}}_label\" type=\"text\" id=\"generic_file_generic_file[{{name}}_attributes][{{index}}][content]\">" +
  "<input name=\"generic_file[{{name}}_attributes][{{index}}][id]\" id=\"generic_file_{{name}}_attributes_0_id\" data-id=\"remote\" type=\"hidden\"/>" +
  "<span class=\"input-group-btn field-controls\">" +
    "<button class=\"btn btn-success add\"><i class=\"icon-white glyphicon-plus\"></i><span>Add</span></button>" +
  "</span>" +
"</li>";

var template = Handlebars.compile(source);

function AgentsFieldManager(element, options) {
  HydraEditor.FieldManager.call(this, element, options); // call super constructor.
}

AgentsFieldManager.prototype = Object.create(HydraEditor.FieldManager.prototype,
  {
    createNewField: { value: function($activeField) {
      var fieldName = $activeField.find('input').data('attribute');
      $newField = this.newFieldTemplate(fieldName);
      this.addBehaviorsToInput($newField)
      return $newField
    }},

    /* This gives the index for the editor */
    maxIndex: { value: function() {
      return $(this.fieldWrapperClass, this.element).size();
    }},

    // Overridden because the input is not a direct child of activeField
    inputIsEmpty: { value: function(activeField) {
      return activeField.find('input.multi-text-field').val() === '';
    }},

    newFieldTemplate: { value: function(fieldName) {
      var index = this.maxIndex();
      return $(template({ "name": fieldName, "index": index, "class": "agent_with_help" }));
    }},

    addBehaviorsToInput: { value: function($newField) {
      $newInput = $('input.multi-text-field', $newField);
      $newInput.focus();
      // TODO: Hook-up QA to this
      //addAutocompleteToEditor($newInput);
      this.element.trigger("managed_field:add", $newInput);
    }},

    // Instead of removing the line, we override this method to add a
    // '_destroy' hidden parameter
    removeFromList: { value: function( event ) {
      event.preventDefault();
      var field = $(event.target).parents(this.fieldWrapperClass);
      field.find('[data-destroy]').val('true')
      field.hide();
      this.element.trigger("managed_field:remove", field);
    }}
  }
);
AgentsFieldManager.prototype.constructor = AgentsFieldManager;

$.fn.manage_comment_fields = function(option) {
  return this.each(function() {
    var $this = $(this);
    var data  = $this.data('manage_fields');
    var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

    if (!data) $this.data('manage_fields', (data = new AgentsFieldManager(this, options)));
  })
}

Blacklight.onLoad(function() {
  $('.agent_with_help.form-group').manage_comment_fields();
});
