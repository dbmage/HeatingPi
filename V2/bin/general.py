def ucFirst(word):
    return "%s%s" % (word[0].upper(), word[1:])

def configSave(my_cwd, config):
    try:
        myfh = open("%s/config/config.json" % (my_cwd), 'w')
        myfh.write(config)
        myfh.close()
        return True
    except (OSError, IOError) as e:
        log.error("Unable to save config: %s" % (e))
        return False
