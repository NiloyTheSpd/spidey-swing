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

  // Swing-cycle frame driver: shoot -> launch -> swing -> apex -> dive -> land.
  property int frame: 0
  Timer {
    interval: 160
    running: true
    repeat: true
    onTriggered: root.frame = (root.frame + 1) % 6
  }

  implicitWidth: 190
  implicitHeight: barSize

  // Traveler: drifts Spidey back and forth through the navbar, facing travel.
  Item {
    id: traveler
    width: 44
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    SequentialAnimation on x {
      loops: Animation.Infinite
      ScriptAction { script: spideyImg.mirror = false }
      NumberAnimation { from: 0; to: 146; duration: 5200; easing.type: Easing.InOutSine }
      ScriptAction { script: spideyImg.mirror = true }
      NumberAnimation { from: 146; to: 0; duration: 5200; easing.type: Easing.InOutSine }
    }

    // Pendulum: gentle sway on top of the per-frame poses.
    Item {
      id: swing
      anchors.fill: parent
      transformOrigin: Item.Top

      SequentialAnimation on rotation {
        loops: Animation.Infinite
        NumberAnimation { from: -8; to: 8; duration: 1500; easing.type: Easing.InOutSine }
        NumberAnimation { from: 8; to: -8; duration: 1500; easing.type: Easing.InOutSine }
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
