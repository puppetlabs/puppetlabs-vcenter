require 'rbvmomi'
require 'puppet/modules/vcenter'
include Puppet::Modules::VCenter

Puppet::Type.type(:vc_folder).provide(:vc_folder) do
  @doc = "Manages vCenter Folders."

  def self.instances
    # list all instances of folder in vCenter.
  end

  def create
    @immediate_parent.create_folder(
        @folder_name,
        "Invalid path for Folder #{@resource[:path]}")
  end

  def destroy
    folder = @immediate_parent.find_child_by_name(@folder_name)
    if folder.is_a?(RbVmomi::VIM::Folder)
      folder.Destroy_Task.wait_for_completion
    else
      raise Puppet::Error.new("#{@resource[:path]} isn't a Folder.")
    end
  end

  def exists?
    lvs = parse_path(@resource[:path])
    @folder_name = lvs.pop
    parent_lvs = lvs
    @immediate_parent ||= find_immediate_parent(
        get_root_folder(@resource[:connection]),
        parent_lvs,
        "Invalid path for Folder #{@resource[:path]}")
    @immediate_parent.find_child_by_name(@folder_name).instance_of?(RbVmomi::VIM::Folder)
  end
end
