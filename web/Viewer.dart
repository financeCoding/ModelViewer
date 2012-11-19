library viewer;

import 'dart:html';
import 'dart:json';

import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';

//---------------------------------------------------------------------
// Source files
//---------------------------------------------------------------------

part 'client/json_object.dart';
part 'client/server_connection.dart';
part 'client/messages.dart';

part 'ui/element_names.dart';
part 'ui/model_selection.dart';
part 'ui/new_file.dart';
part 'ui/tabbed_element.dart';
part 'ui/texture_selection.dart';
part 'ui/renderer_selection.dart';
part 'workspace/application_file_system.dart';
part 'workspace/workspace.dart';

/// Instance of the [Viewer] class.
Viewer _viewer;

class Viewer
{
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Serialization name for the renderer state.
  static const String _rendererStateName = 'rendererState';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [ApplicationFilesystem].
  ApplicationFileSystem _applicationFileSystem;
  /// The current [Workspace].
  Workspace _currentWorkspace;
  /// UI for the model tab.
  ModelSelection _modelSelection;
  /// UI for the textures tab.
  TextureSelection _textureSelection;
  /// UI for the renderer tab.
  RendererSelection _rendererSelection;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /**
   * Creates an instance of the [Viewer] class.
   */
  Viewer()
  {
    _applicationFileSystem = new ApplicationFileSystem();

    _modelSelection = new ModelSelection();
    _textureSelection = new TextureSelection();
    _textureSelection.textureCallback = _onTextureChanged;
    _rendererSelection = new RendererSelection();

    _setupMenuBar();
    _setupUITab();
  }

  /**
   * Initializes the menu bar.
   */
  void _setupMenuBar()
  {
    DivElement newFileButton = query(_ElementNames.newFileButtonName);
    newFileButton.on.click.add((_) {
      newFile();
    });

    DivElement saveFileButton = query(_ElementNames.saveFileButtonName);
    saveFileButton.on.click.add((_) {
      saveFile();
    });
  }

  /**
   * Initializes the UI tabs.
   */
  void _setupUITab()
  {
    TabbedElement element = new TabbedElement();
    element.addTab(_ElementNames.modelTabName, _ElementNames.modelAreaName);
    element.addTab(_ElementNames.textureTabName, _ElementNames.textureAreaName);
    element.addTab(_ElementNames.vertexShaderTabName, _ElementNames.vertexShaderAreaName);
    element.addTab(_ElementNames.fragmentShaderTabName, _ElementNames.fragmentShaderAreaName);
    element.addTab(_ElementNames.uniformTabName, _ElementNames.uniformAreaName);
    element.addTab(_ElementNames.rendererTabName, _ElementNames.rendererAreaName);
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /**
   * Resets the state of the application.
   */
  void newFile()
  {
    _applicationFileSystem.createWorkspace().then((workspace) {
      print('workspace created');
      _currentWorkspace = workspace;
    });

    loadFile(_newFileState);
  }

  /**
   * Saves the state of the application.
   */
  void saveFile()
  {
    Map values = serialize();
    String json = JSON.stringify(values);

    print('Application State\n');
    print(json);
  }

  /**
   * Loads the state of the application from a JSON.
   */
  void loadFile(String json)
  {
    deserialize(JSON.parse(json));
  }

  /**
   * Serializes the state of the application.
   */
  Map serialize()
  {
    Map data = new Map();

    // Append the texture data to the map
    Map textureData = _textureSelection.toJson();

    textureData.forEach((key, value) {
      data[key] = value;
    });

    // Append the renderer state to the map
    Map rendererData = _rendererSelection.toJson();

    rendererData.forEach((key, value) {
      data[key] = value;
    });

    return data;
  }

  /**
   * Deserializes the state of the application.
   */
  void deserialize(Map data)
  {
    _rendererSelection.fromJson(data);
    _textureSelection.fromJson(data);
  }

  //---------------------------------------------------------------------
  // Events
  //---------------------------------------------------------------------

  void _onTextureChanged(File file, int textureUnit)
  {
    _currentWorkspace.saveTexture(file, textureUnit).then((value) {
      // Display the new texture
      _textureSelection.textureUnits[textureUnit].texture = value;
    });
  }
}

void main()
{
  _viewer = new Viewer();
}
