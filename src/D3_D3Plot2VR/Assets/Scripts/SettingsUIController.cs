using System;
using System.Collections.Generic;
using D3Plot;
using SFB;
using UnityEngine;
using UnityEngine.UIElements;

[RequireComponent(typeof(UIDocument))]
public class SettingsUIController : MonoBehaviour {
    private UIDocument _uiDocument;
    private SceneTransition _sceneTransition;
    private D3PlotLoader _loader;
    private string[] _stateFileNames;
    private Label _plotInfo;

    private void Awake() {
        _uiDocument = GetComponent<UIDocument>();
        _sceneTransition = FindObjectOfType<SceneTransition>();

        if (_sceneTransition == null) {
            throw new NullReferenceException("Cannot find a SceneTransition component");
        }

        _loader = FindObjectOfType<D3PlotLoader>(true);

        if (_loader == null) {
            throw new NullReferenceException("Cannot find a D3PlotLoader component");
        }

        DontDestroyOnLoad(_loader);
    }

    private void InitializeVisualTree() {
        VisualElement root = _uiDocument.rootVisualElement;
        List<VisualElement> containers = root.Query<VisualElement>(className: "button-container").ToList();
        foreach (VisualElement element in containers) {
            element.RegisterCallback<ClickEvent>(OnButtonClick);
        }
        
        List<VisualElement> toolbars = root.Query<VisualElement>(className: "toolbar-container").ToList();
        foreach (VisualElement element in toolbars) {
            element.RegisterCallback<ClickEvent>(OnToolButtonClick);
        }

        _plotInfo = root.Query<Label>(name: "plot-info");
        _plotInfo.text = "\n\n\n";

        Button startButton = root.Query<Button>(name: "start");
        startButton.SetEnabled(false);
    }

    private void OnToolButtonClick(ClickEvent evt) {
        if (evt.target is Toggle btn) {
            List<Toggle> toggles = btn.parent.Query<Toggle>().ToList();
            
            foreach (Toggle toggle in toggles) {
                toggle.SetValueWithoutNotify(toggle == btn);
            }

            switch (btn.name) {
                case "up-x":
                    _loader.FlipAxis(Quaternion.AngleAxis(90.0f, Vector3.forward));
                    break;
                case "up-y":
                    _loader.FlipAxis(Quaternion.identity);
                    break;
                case "up-z":
                    _loader.FlipAxis(Quaternion.AngleAxis(-90.0f, Vector3.right));
                    break;
            }
        }
    }

    private void OnButtonClick(ClickEvent evt) {
        if (evt.target is Button btn) {
            if (btn.name == "start") {
                _loader.StateDatabase.LoadStates(_stateFileNames);
                _sceneTransition.TransitionToDesktop("RoomSceneDesktop");
            } else if (btn.name == "load-file") {
                var paths = StandaloneFileBrowser.OpenFilePanel("Open D3Plot file", @"d:\Documents\EdTech-d3plot-data\008", "", false);
                string databaseFileName = paths[0];
                Button startButton = _uiDocument.rootVisualElement.Query<Button>(name: "start");
                try {
                    _loader.LoadDatabase(databaseFileName);
                    _stateFileNames = _loader.EnumerateFiles(databaseFileName);
                    _plotInfo.text = $"Title: {_loader.StateDatabase.Title}\n" +
                                     $"Run time: {_loader.StateDatabase.Control.runtime}\n" +
                                     $"LS-DYNA version {_loader.StateDatabase.Control.ls_dyna_ver}+svn{_loader.StateDatabase.Control.svn_number} release {_loader.StateDatabase.Control.releasenumber}";
                    startButton.SetEnabled(true);
                } catch (UnsupportedFeatureException e) {
                    _plotInfo.text = $"Error: {e.Message}\n\n\n";
                    startButton.SetEnabled(false);
                } catch (FormatException e) {
                    _plotInfo.text = $"Error: {e.Message}\nAre you sure this is a D3Plot file?\n\n";
                    startButton.SetEnabled(false);
                }
            }
                
            evt.StopImmediatePropagation();
        }
    }

    private void OnEnable() {
        InitializeVisualTree();
    }
}