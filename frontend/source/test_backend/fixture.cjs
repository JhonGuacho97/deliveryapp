// Isolated contract server: actual Nest controllers, DTOs, auth guards and
// Socket.IO gateway; in-memory business providers. Never loads AppModule/.env.
const path = require('node:path');
const { createRequire } = require('node:module');
const root = path.resolve(__dirname, '../../../backend/james');
const backend = createRequire(path.join(root, 'package.json'));
backend('reflect-metadata');
backend('tsconfig-paths').register({baseUrl: path.join(root, 'dist'), paths: {'src/*': ['*']}});
const load = (file) => backend(path.join(root, 'dist', file));
const { Test } = backend('@nestjs/testing');
const { JwtModule, JwtService } = backend('@nestjs/jwt');
const { PassportModule } = backend('@nestjs/passport');
const { ConfigService } = backend('@nestjs/config');
const { getRepositoryToken } = backend('@nestjs/typeorm');
const { JwtStrategy } = load('auth/strategies/jwt.strategy');
const { User } = load('auth/entities/user.entity');
const { Session } = load('auth/entities/session.entity');
const { LocationWsGateway } = load('location-ws/location-ws.gateway');
const { LocationWsService } = load('location-ws/location-ws.service');
const { configureApp } = load('configure-app');
const secret = 'isolated-contract-fixture-key-never-used-in-production';
const user = { id:7, isActive:true, email:'client@example.test', fullName:'Cliente de prueba',
  phone:'0991234567', image:'', roles:['client','manager','deliveryman','admin'], addresses:[] };
const address = {id:1, alias:'Casa', address:'Calle 1', location:{x:-0.2,y:-78.5}};
const order = {id:9, note:'', address:'Calle 1', status:1, products:[], deliveryFee:1.5,
  total:8, location:{x:-0.3,y:-78.6}, createdAt:'2026-10-28T12:00:00Z',
  store:{id:5,name:'Comercio',address:'Calle 1',location:{x:-0.2,y:-78.5},company:{image:'',marker:''}},
  notificationsClient:0, payment:5001, deliveryman:null};
const controllers = [];
const providers = [
  JwtStrategy, LocationWsGateway,
  {provide: ConfigService, useValue:{getOrThrow:()=>secret}},
  {provide:getRepositoryToken(User), useValue:{findOneBy:async()=>user}},
  {provide:getRepositoryToken(Session), useValue:{findOneBy:async()=>({id:1})}},
  {provide:LocationWsService,useValue:{registerUser:async(socket)=>{socket.isAuth=true;socket.data.actor={id:7,idDevice:'0a824db1-708e-4bf1-a50d-76c441073069',roles:user.roles};},canWatch:async()=>true,watcherIds:async()=>[7],updateLocation:async()=>true}},
];
function add(controllerFile, controllerName, serviceFile, serviceName, methods) {
  controllers.push(load(controllerFile)[controllerName]);
  providers.push({provide:load(serviceFile)[serviceName],useValue:methods});
}
const response = (value) => async () => value;
async function main() {
  const jwt = new JwtService({secret});
  const token = jwt.sign({id:7,idDevice:'0a824db1-708e-4bf1-a50d-76c441073069'});
  add('auth/auth.controller','AuthController','auth/auth.service','AuthService',{
    login:response({...user,token}), register:response({...user,token}), google:response({...user,token}),
    checkStatus:response({...user,token}), update:response({...user,token}), updatePasswor:response({}),
    recoverAccount:response({}), updateTokenPush:response({}), logOut:response({}),
  });
  add('client/market/market.controller','MarketController','client/market/market.service','MarketService',{
    findCompanies:response({companies:[],products:[]}),findCategories:response({categories:[]}),
    findProductsByCompany:response({products:[]}),deliveryCost:response({fees:[{name:'Comercio',companyId:2,image:'',marker:'',store_id:5,deliveryfee:1.5}]}),
    findOrders:response({orders:[order]}),findOrder:response({order}),buy:response({id:9}),qualify:response({}),
  });
  add('client/address/address.controller','AddressController','client/address/address.service','AddressService',{
    findAll:response({addresses:[address]}),create:response({address}),update:response({address}),remove:response({}),
    geocode:response({locations:[address.location]}),autocomplete:response({predictions:[]}),
  });
  add('client/balance/balance.controller','BalanceController','client/balance/balance.service','BalanceService',{
    findOne:response({balance:{userId:7,balance:10,profit:0,amount:10,money:10}}),
  });
  add('client/payments/payments.controller','PaymentsController','client/payments/payments.service','PaymentsService',{
    create:response({id:9,response:{client_secret:'pi_fixture_secret'}}),confirm:response({}),cancel:response({}),
  });
  add('chat/chat.controller','ChatController','chat/chat.service','ChatService',{
    findByOrder:response({messages:[]}),send:response({}),markAllRead:response({}),
  });
  add('manager/store-manager/store.manager.controller','StoreManagerController','manager/store-manager/store.manager.service','StoreManagerService',{
    companies:response({stores:[]}),products:response({products:[]}),hours:response({hours:[]}),
  });
  add('manager/request/request.controller','RequestController','manager/request/request.service','RequestService',{
    findNearRequests:response({requests:[]}),history:response({requests:[]}),
  });
  add('deliveryman/petition/petition.controller','PetitionController','deliveryman/petition/petition.service','PetitionService',{
    findNearPetitions:response({petitions:[],isOnline:false}),history:response({petitions:[]}),activate:response(true),
  });
  add('manager/enrollment/enrollment.controller','EnrollmentController','manager/enrollment/enrollment.service','EnrollmentService',{
    getCategories:response({categories:[]}),create:response({}),
  });
  add('admin/credit/credit.controller','CreditController','admin/credit/credit.service','CreditService',{
    topUpBalance:response({}),
  });
  const module = await Test.createTestingModule({controllers,providers,
    imports:[PassportModule.register({defaultStrategy:'jwt'}),JwtModule.register({secret})],
  }).compile();
  const app = module.createNestApplication({logger:false});
  configureApp(app);
  await app.listen(0,'127.0.0.1');
  process.stdout.write(JSON.stringify({port:app.getHttpServer().address().port,token})+'\n');
  process.stdin.resume();
  process.stdin.on('data',async()=>{await app.close();process.exit(0);});
}
main().catch(error=>{process.stderr.write(error.stack+'\n');process.exit(1);});
