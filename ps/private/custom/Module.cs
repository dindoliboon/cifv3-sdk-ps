// https://github.com/Azure/autorest.incubator/blob/master/Examples/TimesWire/generated/private/custom/Module.cs
namespace Cif.V3.Management
{
    using Runtime;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Net.Http.Headers;

    /// <summary>A class that contains the module-common code and data.</summary>
    /// <notes>
    /// This class is where you can add things to modify the module.
    /// As long as it's in the 'private/custom' folder, it won't get deleted
    /// when you use --clear-output-folder in autorest.
    /// </notes>
    public partial class Module
    {
        partial void CustomInit()
        {
            // we need to add a step at the end of the pipeline
            // to attach the API key

            // once for the regular pipeline
            this._pipeline.Append(AddApiKey);

            // once for the pipeline that supports a proxy
            this._pipelineWithProxy.Append(AddApiKey);
        }

        protected async Task<HttpResponseMessage> AddApiKey(HttpRequestMessage request, IEventListener callback, ISendAsync next)
        {
            request.Headers.Add("Authorization", "Token token=" + System.Environment.GetEnvironmentVariable("CifV3ApiKey"));

            // let it go on.
            return await next.SendAsync(request, callback);
        }
    }
}
