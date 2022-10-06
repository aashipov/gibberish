var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

const string welcome = "Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish";

app.Map("/{*any}", async (HttpRequest request) =>
{
    if (request.Method.ToLower().Equals("post"))
    {
        try
        {
            using (StreamReader stream = new StreamReader(request.Body))
            {
                string b = await stream.ReadToEndAsync();
                return System.Guid.NewGuid() + b + System.Guid.NewGuid() + "\n";
            }
        }
        catch (Exception e)
        {
            return e.Message.ToString();
        }
    }
    return welcome;
}
);

app.Run();
