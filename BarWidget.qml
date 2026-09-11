import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "thespd.spidey"

  // Click contract for the bar host: the bar only delivers clicks to
  // registered targets (or the widget root) via triggerPress().
  function triggerPress(button) {
    if (button === undefined || button === Qt.LeftButton) flipAnim.restart()
  }

  property var registeredBar: null
  function syncClickTarget() {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
    registeredBar = bar
    if (registeredBar && registeredBar.registerClickTarget) registeredBar.registerClickTarget(root)
  }
  onBarChanged: syncClickTarget()
  Component.onCompleted: syncClickTarget()
  Component.onDestruction: {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
  }

  // Swing-cycle frame driver with cinematic timing: slow anticipation,
  // snappy action, hangtime at the apex, a held impact beat, and rest.
  // shoot / launch / swing / apex / dive / wallrun / land / perch
  property int frame: 0
  readonly property var frameTime: [420, 150, 150, 320, 130, 170, 480, 520]
  Timer {
    interval: root.frameTime[root.frame]
    running: true
    repeat: true
    onTriggered: root.frame = (root.frame + 1) % 8
  }

  implicitWidth: 190
  implicitHeight: barSize

  // Rooftop skyline parallax drifting behind the action.
  Item {
    anchors.fill: parent
    clip: true
    Row {
      anchors.bottom: parent.bottom
      height: 26
      spacing: 6
      SequentialAnimation on x {
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: -100; duration: 22000; easing.type: Easing.InOutSine }
        NumberAnimation { from: -100; to: 0; duration: 22000; easing.type: Easing.InOutSine }
      }
      Repeater {
        model: [
          {w: 20, h: 12}, {w: 14, h: 20}, {w: 26, h: 10}, {w: 16, h: 24},
          {w: 22, h: 14}, {w: 12, h: 18}, {w: 24, h: 11}, {w: 18, h: 22},
          {w: 20, h: 12}, {w: 14, h: 20}, {w: 26, h: 10}, {w: 16, h: 24}
        ]
        Rectangle {
          required property int index
          required property var modelData
          width: modelData.w
          height: modelData.h
          anchors.bottom: parent.bottom
          color: "#0b0d13"
          Rectangle {
            width: 3
            height: 4
            x: 4
            y: 4
            color: "#e9bb4f"
            opacity: 0.45
            visible: (parent.index % 2) === 0
          }
        }
      }
    }
  }

  // Traveler: drifts Spidey back and forth through the navbar, facing travel.
  Item {
    id: traveler
    width: 44
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    SequentialAnimation on x {
      loops: Animation.Infinite
      ScriptAction { script: spideyImg.mirror = false }
      NumberAnimation { from: 0; to: 146; duration: 7600; easing.type: Easing.InOutSine }
      ScriptAction { script: spideyImg.mirror = true }
      NumberAnimation { from: 146; to: 0; duration: 7600; easing.type: Easing.InOutSine }
    }

    // Pendulum: gentle sway on top of the per-frame poses.
    Item {
      id: swing
      anchors.fill: parent
      transformOrigin: Item.Top

      SequentialAnimation on rotation {
        loops: Animation.Infinite
        NumberAnimation { from: -7; to: 7; duration: 2100; easing.type: Easing.InOutSine }
        NumberAnimation { from: 7; to: -7; duration: 2100; easing.type: Easing.InOutSine }
      }

      // Flipper: somersaults on click, independent of swing + travel.
      Item {
        id: flipper
        anchors.fill: parent
        transformOrigin: Item.Center

        NumberAnimation {
          id: flipAnim
          target: flipper
          property: "rotation"
          from: 0
          to: 360
          duration: 600
          easing.type: Easing.InOutQuad
        }

        Image {
          id: spideyImg
          anchors.centerIn: parent
          height: parent.height
          fillMode: Image.PreserveAspectFit
          smooth: true
          source: "assets/frames/frame" + root.frame + ".svg"
        }
      }
    }
  }
}
