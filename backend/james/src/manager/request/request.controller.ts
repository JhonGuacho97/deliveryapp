import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
} from '@nestjs/common';
import { AcceptRequestDto } from './dto/accept-request.dto';
import { HistoryRequestDto } from './dto/history-request.dto';
import { RequestService } from './request.service';
import { Auth, GetUser } from 'src/auth/decorators';
import { TypesRol } from 'src/common/glob/types';
import { User } from 'src/auth/entities/user.entity';

@Controller('manager/request')
export class RequestController {
  constructor(private readonly requestService: RequestService) {}

  @Patch(':orderId/accept')
  @Auth(TypesRol.manager)
  accept(
    @Param('orderId', ParseIntPipe) orderId: number,
    @GetUser() user: User,
    @Body() dto: AcceptRequestDto,
  ) {
    return this.requestService.accept(user, orderId, dto.preparationMinutes);
  }

  @Patch(':orderId/ready')
  @Auth(TypesRol.manager)
  ready(
    @Param('orderId', ParseIntPipe) orderId: number,
    @GetUser() user: User,
  ) {
    return this.requestService.ready(user, orderId);
  }

  @Get('near')
  @Auth(TypesRol.manager)
  findNearRequests(@GetUser() user: User) {
    return this.requestService.findNearRequests(user);
  }

  @Get('id/:orderId')
  @Auth(TypesRol.manager)
  findRequest(
    @Param('orderId', ParseIntPipe) orderId: number,
    @GetUser() user: User,
  ) {
    return this.requestService.findRequest(user, orderId);
  }

  @Get('ordered-at/:orderedAt')
  @Auth(TypesRol.manager)
  history(@Param() params: HistoryRequestDto, @GetUser() user: User) {
    return this.requestService.history(user, params.orderedAt);
  }
}
