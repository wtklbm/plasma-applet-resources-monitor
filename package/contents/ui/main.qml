import org.kde.kio 1.0 as Kio
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import QtGraphicalEffects 1.0
import QtQuick 2.5
import QtQuick.Layouts 1.1

Item {
    id: main
    anchors.fill: parent

    property bool memoryInPercent: true
    property bool showMemoryInPercent: memoryInPercent

    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double itemWidth:  parentHeight
    property double itemHeight: parentHeight * 1.6
    property double fontPixelSize: itemHeight * 0.32

    Layout.preferredWidth: itemWidth * 2 + fontPixelSize * 2 // 边距
    Layout.preferredHeight: itemWidth

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    Kio.KRun {
        id: kRun
    }

    PlasmaCore.DataSource {
        id: apps
        engine: 'apps'
        property string ksysguardSource: 'org.kde.ksysguard.desktop'
        connectedSources: [ ksysguardSource ]
    }

    PlasmaCore.DataSource {
        engine: "systemmonitor"

        property string totalLoad: "cpu/system/TotalLoad"

        connectedSources: [ totalLoad ]

        onNewData: {
            if (data.value == null) {
                return
            }

            if (sourceName === totalLoad) {
                cpuPercentText.text = Math.round(data.value) + ' %'
            }
        }

        interval: 1000 * 1
    }

    PlasmaCore.DataSource {
        engine: "systemmonitor"

        property string averageCoreHot:  "lmsensors/coretemp-isa-0000/Package_id_0"

        connectedSources: [ averageCoreHot ]

        onNewData: {
            if (data.value == null) {
                return
            }

            if (sourceName === averageCoreHot) {
                averageCoreHotText.text = parseInt(data.value) + " ° "
            }
        }

        interval: 1000 * 10
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "systemmonitor"

        property string memPhysical: "mem/physical/"
        property string memFree: memPhysical + "free"
        property string memApplication: memPhysical + "application"
        property string memUsed: memPhysical + "used"
        property string swap: "mem/swap/"
        property string swapUsed: swap + "used"
        property string swapFree: swap + "free"

        property int ramUsedBytes: 0
        property double ramUsedProportion: 0
        property int swapUsedBytes: 0
        property double swapUsedProportion: 0

        connectedSources: [memFree, memUsed, memApplication, swapUsed, swapFree ]

        onNewData: {
            if (data.value == null) {
                return
            }

            if (sourceName === memApplication) {
                ramUsedBytes = parseInt(data.value)
                ramUsedProportion = fitMemoryUsage(data.value)
                setMemText()
            } else if (sourceName === swapUsed) {
                swapUsedBytes = parseInt(data.value)
                swapUsedProportion = fitSwapUsage(data.value)
                setSwapText()
            }
        }

        interval: 1000 * 5
    }

    function setMemText() {
        ramPercentText.text = Math.round(dataSource.ramUsedProportion * 100) + ' %'
    }

    function setSwapText() {
        if (dataSource.swapUsedProportion > 0) {
            swapPercentText.text = Math.round(dataSource.swapUsedProportion * 100) + ' %'
            return
        }

        swapPercentText.text = '0 %'
    }

    function fitMemoryUsage(usage) {
        var memFree = dataSource.data[dataSource.memFree]
        var memUsed = dataSource.data[dataSource.memUsed]

        if (!memFree || !memUsed) {
            return 0
        }

        return (usage / (parseFloat(memFree.value) +
                         parseFloat(memUsed.value)))
    }

    function fitSwapUsage(usage) {
        var swapFree = dataSource.data[dataSource.swapFree]

        if (!swapFree) {
            return 0
        }

        return (usage / (parseFloat(usage) + parseFloat(swapFree.value)))
    }

    function getReadableMemory(memBytes) {
        var megaBytes = memBytes / 1024

        if (megaBytes <= 1024) {
            return Math.round(megaBytes) + ' M'
        }

        return Math.round(megaBytes / 1024 * 100) / 100 + ' G'
    }

    Item {
        id: cpuMonitor
        width: itemWidth
        height: itemHeight

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: itemWidth - fontPixelSize // 边距


        Item {
            id: cpuTextContainer
            anchors.fill: parent
            anchors.topMargin: -2

            // CPU
            PlasmaComponents.Label {
                id: cpuPercentText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                font.pixelSize: fontPixelSize
                text: '0 %'
            }

            // 温度
            PlasmaComponents.Label {
                id: averageCoreHotText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                text: '0 ° '
            }
        }
    }

    Item {
        id: ramMonitor
        width: itemWidth
        height: itemHeight

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: itemWidth + fontPixelSize * 2.5 // 边距


        Item {
            id: ramTextContainer
            anchors.fill: parent
            anchors.topMargin: -2

            // RAM
            PlasmaComponents.Label {
                id: ramPercentText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                font.pixelSize: fontPixelSize
                text: '0 %'
            }

            // SWAP
            PlasmaComponents.Label {
                id: swapPercentText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                text: '0 %'
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            // 鼠标滑入
            onEntered: {
                ramPercentText.text = getReadableMemory(dataSource.ramUsedBytes)
                swapPercentText.text = getReadableMemory(dataSource.swapUsedBytes)
            }

            // 鼠标滑出
            onExited: {
                setMemText()
                setSwapText()
            }
        }
    }
}
