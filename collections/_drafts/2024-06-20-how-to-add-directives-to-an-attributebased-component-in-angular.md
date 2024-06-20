---
layout: post
title: How to add directives to an attribute-based component in Angular
date: '2024-06-20 23:14:25 +0200'
comments: true
categories: programming
---

Hello, World!

<!-- more -->

```ts
@Component({
  selector: '[app-reservation-widget-row]',
  standalone: true,
  imports: [SharedModule, TableRowLinkDirective, UserLinkComponent],
  hostDirectives: [
    {
      directive: TableRowLinkDirective,
      inputs: ['tableRowLink']
    }
  ],
  templateUrl: './reservation-widget-row.component.html',
  styleUrl: './reservation-widget-row.component.css'
})
export class ReservationWidgetRowComponent {
  @Input({ required: true })
  reservation!: Reservation;

  readonly DateTime = DateTime;
  readonly UserType = UserType;

  constructor(readonly reservationService: ReservationService) {}
}
```

```html
<tr
  *ngIf="cast(item, Reservation) as reservation"
  app-reservation-widget-row
  [reservation]="reservation"
  [tableRowLink]="['/reservations', reservation.id]"
></tr>
```
