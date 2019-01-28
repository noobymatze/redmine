module Request.Issues.Filter exposing (Filter, emptyFilter, toQuery)

import Url.Builder as Url exposing (QueryParameter)
import Url.Builder.Extra as Url



-- FILTER


type alias Filter =
    { issueId : Maybe Int
    , projectId : Maybe Int
    , subprojectId : Maybe Int
    , trackerId : Maybe Int
    , statusId : Maybe Int
    , assignedToId : Maybe Int
    , parentId : Maybe Int
    , offset : Int
    , limit : Int
    }


emptyFilter : Filter
emptyFilter =
    { issueId = Nothing
    , projectId = Nothing
    , subprojectId = Nothing
    , trackerId = Nothing
    , statusId = Nothing
    , assignedToId = Nothing
    , parentId = Nothing
    , offset = 0
    , limit = 100
    }


toQuery : Filter -> List QueryParameter
toQuery filter =
    List.filterMap identity
        [ Url.maybe "issueId" Url.int filter.issueId
        , Url.maybe "projectId" Url.int filter.projectId
        , Url.maybe "subprojectId" Url.int filter.subprojectId
        , Url.maybe "trackerId" Url.int filter.trackerId
        , Url.maybe "assignedToId" Url.int filter.assignedToId
        , Url.maybe "parentId" Url.int filter.parentId
        , Just (Url.int "offset" filter.offset)
        , Just (Url.int "limit" filter.limit)
        ]
