import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "thespd.spidey"

  // Click contract for the bar host: the bar only delivers clicks to
  // registered targets (or the widget root) via triggerPress().
  function triggerPress(button) {
    console.log("spidey flip")
    if (button === undefined || button === Qt.LeftButton) flipAnim.restart()
  }

  property var registeredBar: null
  function syncClickTarget() {
    console.log("spidey sync bar=" + (bar ? "set" : "null") + " regFn=" + (bar && typeof bar.registerClickTarget))
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
    registeredBar = bar
    if (registeredBar && registeredBar.registerClickTarget) registeredBar.registerClickTarget(root)
  }
  onBarChanged: syncClickTarget()
  Component.onCompleted: syncClickTarget()
  Component.onDestruction: {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
  }

  // Miles Morales palette (matches cursor + theme)
  readonly property color suitBlack: "#1a1c24"
  readonly property color spiderRed: "#ff1e2d"
  readonly property color eyeWhite: "#ffffff"
  readonly property color webGrey: "#8a8f9e"

  implicitWidth: 26
  implicitHeight: barSize

  // Whole assembly pivots from the top of the bar like a pendulum.
  Item {
    id: swing
    anchors.fill: parent
    transformOrigin: Item.Top

    SequentialAnimation on rotation {
      loops: Animation.Infinite
      NumberAnimation { from: -16; to: 16; duration: 1200; easing.type: Easing.InOutSine }
      NumberAnimation { from: 16; to: -16; duration: 1200; easing.type: Easing.InOutSine }
    }

    // Web thread
    Rectangle {
      width: 2
      height: 9
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.webGrey
      opacity: 0.85
    }

    // Flipper: somersaults on click, independent of the pendulum swing
    Item {
      id: flipper
      anchors.top: parent.top
      anchors.topMargin: 9
      anchors.horizontalCenter: parent.horizontalCenter
      width: 26
      height: 22
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

    // Spider body
    Rectangle {
      id: body
      width: 10
      height: 12
      radius: 5
      anchors.top: parent.top
      anchors.topMargin: 0
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.suitBlack
      border.color: root.spiderRed
      border.width: 1
    }

    // Head
    Rectangle {
      id: head
      width: 12
      height: 10
      radius: 5
      anchors.top: body.bottom
      anchors.topMargin: -2
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.suitBlack
      border.color: root.spiderRed
      border.width: 1

      // Left eye
      Rectangle {
        width: 4
        height: 6
        radius: 2
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.verticalCenter: parent.verticalCenter
        rotation: -18
        color: root.eyeWhite
        border.color: root.spiderRed
        border.width: 1
      }

      // Right eye
      Rectangle {
        width: 4
        height: 6
        radius: 2
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.verticalCenter: parent.verticalCenter
        rotation: 18
        color: root.eyeWhite
        border.color: root.spiderRed
        border.width: 1
      }
    }

    // Legs: three thin limbs per side
    Repeater {
      model: 3
      Rectangle {
        required property int index
        width: 7
        height: 1.5
        radius: 1
        color: root.suitBlack
        border.color: root.spiderRed
        border.width: 0.5
        x: body.x - 6 + index * 1.5
        y: body.y + 2 + index * 3.5
        rotation: -35 + index * 8
        transformOrigin: Item.Right
      }
    }

    Repeater {
      model: 3
      Rectangle {
        required property int index
        width: 7
        height: 1.5
        radius: 1
        color: root.suitBlack
        border.color: root.spiderRed
        border.width: 0.5
        x: body.x + body.width - 1 - index * 1.5
        y: body.y + 2 + index * 3.5
        rotation: 35 - index * 8
        transformOrigin: Item.Left
      }
    }
    } // flipper
  }
}
