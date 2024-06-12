sam_cr_path = "../../sam.cr"
template_path = "examples/sam.template"

if !File.exists?(sam_cr_path)
  File.copy(template_path, sam_cr_path)
end
