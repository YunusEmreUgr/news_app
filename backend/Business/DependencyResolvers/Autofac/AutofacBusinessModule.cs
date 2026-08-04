using Autofac;
using Autofac.Extras.DynamicProxy;
using Business.Abstract;
using Business.BusinessRules;
using Business.Concrete;
using Castle.DynamicProxy;
using Core.Utilities.Interceptors;
using Core.DataAccess;
using Core.Utilities.Security.JWT;
using DataAccess.Abstract;
using DataAccess.Concrete.EntityFramework;

namespace Business.DependencyResolvers.Autofac
{
    public class AutofacBusinessModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            // DataAccess Registrations
            builder.RegisterType<EfCategoryDal>().As<ICategoryDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfArticleDal>().As<IArticleDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfCommentDal>().As<ICommentDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfBookmarkDal>().As<IBookmarkDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfUserDal>().As<IUserDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfOperationClaimDal>().As<IOperationClaimDal>().InstancePerLifetimeScope();
            builder.RegisterType<EfUserOperationClaimDal>().As<IUserOperationClaimDal>().InstancePerLifetimeScope();
            builder.RegisterType<RefreshTokenRepository>().As<IRefreshTokenRepository>().InstancePerLifetimeScope();

            // Core & Auth
            builder.RegisterType<JwtHelper>().As<ITokenHelper>().SingleInstance();
            builder.RegisterType<GoogleAuthService>().As<IGoogleAuthService>().InstancePerLifetimeScope();
            builder.RegisterType<AppleAuthService>().As<IAppleAuthService>().InstancePerLifetimeScope();

            // Manager registrations via AOP Assembly scanner
            var assembly = System.Reflection.Assembly.GetExecutingAssembly();

            builder.RegisterAssemblyTypes(assembly)
                .Where(t => t.Name.EndsWith("Manager"))
                .AsImplementedInterfaces()
                .EnableInterfaceInterceptors(new ProxyGenerationOptions
                {
                    Selector = new AspectInterceptorSelector()
                })
                .InstancePerLifetimeScope();
        }
    }
}
