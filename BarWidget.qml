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

  implicitWidth: 150
  implicitHeight: barSize

  // Traveler: drifts Spidey back and forth through the navbar.
  Item {
    id: traveler
    width: 40
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    SequentialAnimation on x {
      loops: Animation.Infinite
      ScriptAction { script: spideyImg.mirror = false }
      NumberAnimation { from: 0; to: 110; duration: 4200; easing.type: Easing.InOutSine }
      ScriptAction { script: spideyImg.mirror = true }
      NumberAnimation { from: 110; to: 0; duration: 4200; easing.type: Easing.InOutSine }
    }

    // Pendulum: pivots from the web anchor (top-right of the art).
    Item {
      id: swing
      anchors.fill: parent
      transformOrigin: Item.TopRight

      SequentialAnimation on rotation {
        loops: Animation.Infinite
        NumberAnimation { from: -12; to: 12; duration: 1400; easing.type: Easing.InOutSine }
        NumberAnimation { from: 12; to: -12; duration: 1400; easing.type: Easing.InOutSine }
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
          source: "assets/miles-swing.png"
        }
      }
    }
  }
}
