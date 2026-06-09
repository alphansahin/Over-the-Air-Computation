def parse_command(text):
    parts = text.strip().split()
    
    command = parts[0]
    kwargs = {}
    
    for item in parts[1:]:
        if "=" in item:
            key, value = item.split("=", 1)
            kwargs[key] = value
    
    return command, kwargs


def overwriteParameters(obj, **kwargs):
    for key, value in kwargs.items():
        if hasattr(obj, key):
            setattr(obj, key, value)
        else:
            print(f"Object of type '{type(obj).__name__}' does not have an attribute named '{key}'.")
