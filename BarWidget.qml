import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "thespd.spidey"

  // Click contract for the bar host: the bar only delivers clicks to
  // registered targets (or the widget root) via triggerPress().
  // Restart is immediate (<100ms) and idempotent under spam.
  function triggerPress(button) {
    if (button === undefined || button === Qt.LeftButton) flipSeq.restart()
  }

  property var registeredBar: null
  function syncClickTarget() {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
    registeredBar = bar
    if (registeredBar && registeredBar.registerClickTarget) registeredBar.registerClickTarget(root)
  }
  onBarChanged: syncClickTarget()
  Component.onCompleted: {
    syncClickTarget()
    imgA.source = frameSrc
  }
  Component.onDestruction: {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
  }

  // Nine staged keys: 5 heroes (shoot / swing / dive / land / perch)
  // + 3 body in-betweens (anticipate / tuck / reach) + 1 eye beat
  // (perch-blink). The blink punctuates the rest hold so the lenses
  // feel alive; land carries an impact squint baked into frame3.
  // Cycle order maps to files to keep hero names stable.
  property int frame: 0
  readonly property var frameOrder: [0, 5, 1, 6, 2, 7, 3, 4, 8]
  readonly property var frameTime: [480, 160, 220, 150, 160, 170, 520, 420, 140]
  readonly property string frameSrc: "assets/frames/frame" + frameOrder[frame] + ".svg"
  Timer {
    interval: root.frameTime[root.frame]
    running: true
    repeat: true
    onTriggered: root.frame = (root.frame + 1) % 9
  }

  // Pre-cache all keys once so frame swaps never hit disk mid-cycle.
  // Hidden 1px images decode + cache; no per-frame allocation.
  Repeater {
    model: 9
    Image {
      width: 1
      height: 1
      visible: false
      source: "assets/frames/frame" + frameOrder[index] + ".svg"
    }
  }

  implicitWidth: 190
  implicitHeight: barSize

  // Traveler: slow drift through the navbar, facing travel direction.
  // GPU-only motion (x / y / rotation / scale / opacity) at 60fps.
  // Secondary motion (bob + lean + squash) is interpolated every frame,
  // so the 8 discrete SVG keys read as continuous movement.
  property bool facingLeft: false
  property real leanTarget: 0
  Item {
    id: traveler
    width: 44
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    SequentialAnimation on x {
      loops: Animation.Infinite
      ScriptAction {
        script: {
          root.facingLeft = false
          root.leanTarget = 5
          imgA.mirror = false
          imgB.mirror = false
        }
      }
      NumberAnimation { from: 0; to: 146; duration: 9000; easing.type: Easing.InOutSine }
      ScriptAction {
        script: {
          root.facingLeft = true
          root.leanTarget = -5
          imgA.mirror = true
          imgB.mirror = true
        }
      }
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

    // Bob: gentle vertical float, lags behind horizontal travel.
    Item {
      id: bob
      anchors.fill: parent
      SequentialAnimation on y {
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: -2; duration: 1100; easing.type: Easing.InOutSine }
        NumberAnimation { from: -2; to: 1; duration: 1300; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1; to: 0; duration: 900; easing.type: Easing.InOutSine }
      }

      // Lean: torso inclination into travel direction + pose lean.
      // Overshoots slightly on direction change, then settles.
      Item {
        id: lean
        anchors.fill: parent
        rotation: root.leanTarget + poseLean
        property real poseLean: 0
        Behavior on rotation {
          NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
        }

        // Flipper: somersaults on click with a subtle scale swell
        // (anticipation -> action -> settle). Squash on land / stretch
        // in air is driven per-frame below.
        Item {
          id: flipper
          anchors.fill: parent
          transformOrigin: Item.Center
          scale: 1.0
          property real squashX: 1.0
          property real squashY: 1.0
          transform: Scale {
            origin.x: flipper.width / 2
            origin.y: flipper.height / 2
            xScale: flipper.squashX * flipper.scale
            yScale: flipper.squashY * flipper.scale
          }
          Behavior on squashX { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.7 } }
          Behavior on squashY { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.7 } }

          SequentialAnimation {
            id: flipSeq
            ParallelAnimation {
              NumberAnimation { target: flipper; property: "rotation"; from: 0; to: 360; duration: 600; easing.type: Easing.InOutQuad }
              SequentialAnimation {
                NumberAnimation { target: flipper; property: "scale"; from: 1.0; to: 1.12; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { target: flipper; property: "scale"; from: 1.12; to: 1.0; duration: 420; easing.type: Easing.InOutCubic }
              }
            }
          }

          // Crossfade pair: the incoming key fades in over ~90ms while
          // the outgoing fades out — no blank frame, no hard pop.
          Image {
            id: imgA
            anchors.centerIn: parent
            height: parent.height
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: showA ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
          }
          Image {
            id: imgB
            anchors.centerIn: parent
            height: parent.height
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: showA ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
          }
        }
      }
    }
  }

  property bool showA: true
  onFrameSrcChanged: {    if (showA) {
      imgB.source = frameSrc
      showA = false
    } else {
      imgA.source = frameSrc
      showA = true
    }
    // Pose-driven secondary motion: squash on impact, stretch in air.
    var f = frameOrder[frame]
    if (f === 3) {
      flipper.squashX = 1.14
      flipper.squashY = 0.86
      lean.poseLean = -3
    } else if (f === 5) {
      flipper.squashX = 1.06
      flipper.squashY = 0.94
      lean.poseLean = -2
    } else if (f === 1 || f === 2 || f === 6) {
      flipper.squashX = 0.94
      flipper.squashY = 1.07
      lean.poseLean = 4
    } else if (f === 0) {
      flipper.squashX = 1.0
      flipper.squashY = 1.0
      lean.poseLean = 2
    } else {
      flipper.squashX = 1.0
      flipper.squashY = 1.0
      lean.poseLean = 0
    }
  }
}
