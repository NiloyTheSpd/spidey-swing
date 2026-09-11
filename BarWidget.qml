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

  // Five staged keys, one readable action each: shoot / swing / dive /
  // land / perch. Long holds so every pose registers at bar size.
  property int frame: 0
  readonly property var frameTime: [500, 220, 160, 550, 600]
  Timer {
    interval: root.frameTime[root.frame]
    running: true
    repeat: true
    onTriggered: root.frame = (root.frame + 1) % 5
  }

  implicitWidth: 190
  implicitHeight: barSize

  // Traveler: slow drift through the navbar, facing travel direction.
  // The only continuous motion — poses stay clean and readable.
  Item {
    id: traveler
    width: 44
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    SequentialAnimation on x {
      loops: Animation.Infinite
      ScriptAction { script: spideyImg.mirror = false }
      NumberAnimation { from: 0; to: 146; duration: 9000; easing.type: Easing.InOutSine }
      ScriptAction { script: spideyImg.mirror = true }
      NumberAnimation { from: 146; to: 0; duration: 9000; easing.type: Easing.InOutSine }
    }

    // Separation glow: lifts the black suit off dark bars.
    Image {
      anchors.centerIn: parent
      width: 96
      height: 48
      source: "assets/backdrop.svg"
      smooth: true
      opacity: 0.9
    }

    // Flipper: somersaults on click.
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
