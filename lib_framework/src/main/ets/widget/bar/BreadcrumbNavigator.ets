import { BreadcrumbSegment } from '../../model/BreadcrumbSegment'

@Component
export struct BreadcrumbNavigator {
  @Prop @Watch('onSegmentsChanged') segments: BreadcrumbSegment[] = []
  onSegmentClick: (index: number) => void = () => {}

  private scroller: Scroller = new Scroller()

  onSegmentsChanged(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.End)
    }, 0)
  }

  aboutToAppear(): void {
    this.onSegmentsChanged()
  }

  build() {
    Scroll(this.scroller) {
      Row({ space: 4 }) {
        ForEach(this.segments, (segment: BreadcrumbSegment, index: number) => {
          if (index > 0) {
            Text('/')
              .fontSize(14)
              .fontColor($r('sys.color.font_tertiary'))
          }

          Text(segment.label)
            .fontSize(14)
            .fontColor(segment.isCurrent ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
            .fontWeight(segment.isCurrent ? FontWeight.Medium : FontWeight.Normal)
            .maxLines(1)
            .onClick(() => {
              if (!segment.isCurrent) {
                this.onSegmentClick(index)
              }
            })
        }, (segment: BreadcrumbSegment, index: number) => `${segment.path}_${index}`)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(36)
    .align(Alignment.Start)
  }
}
